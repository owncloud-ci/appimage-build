def main(ctx):
  dists = {
    'centos7': {
      'builds': [
        {
          'tag_suffixes': ['latest', 'devtoolset9'],
          'build_args': {
            'DEVTOOLSET_VERSION': 9,
          }
        },
        {
          'tag_suffixes': ['devtoolset11'],
          'build_args': {
            'DEVTOOLSET_VERSION': 9,
          }
        },
      ]
    }
  }

  arches = [
    'amd64',
  ]

  config = {
    'version': None,
    'arch': None,
    'trigger': [],
    'repo': ctx.repo.name
  }

  stages = []

  for dist_name, dist_config in dists.items():
    config['version'] = dist_name

    # unlike other repositories, e.g., appimage-deployment, this repo manages different distributions
    config['path'] = dist_name

    for build in dist_config['builds']:
      inner = []

      for arch in arches:
        config['arch'] = arch

        tags = []
        for tag_suffix in build['tag_suffixes']:
          tags.append('%s-%s-%s' % (config['version'], tag_suffix, arch))
        config['tags'] = tags

        if config['arch'] == 'amd64':
          config['platform'] = 'amd64'

        if config['arch'] == 'arm64v8':
          config['platform'] = 'arm64'

        if config['arch'] == 'arm32v7':
          config['platform'] = 'arm'

        config['internal'] = '%s-%s' % (ctx.build.commit, config['tags'][0])

        m = manifest(config)

        d = docker(config)
        m['depends_on'].append(d['name'])

        inner.append(d)

        inner.append(m)

      stages.extend(inner)

  after = [
    notification(config),
  ]

  for s in stages:
    for a in after:
      a['depends_on'].append(s['name'])

  return stages + after

def docker(config):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': '%s-%s' % (config['arch'], config['tags'][0]),
    'platform': {
      'os': 'linux',
      'arch': config['platform'],
    },
    'steps': steps(config),
    'image_pull_secrets': [
      'registries',
    ],
    'depends_on': [],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/pull/**',
      ],
    },
  }

def manifest(config):
  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'manifest-%s' % config['tags'][0],
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'steps': [
      {
        'name': 'manifest',
        'image': 'plugins/manifest',
        'settings': {
          'username': {
            'from_secret': 'public_username',
          },
          'password': {
            'from_secret': 'public_password',
          },
          'spec': '%s/manifest.tmpl' % config['path'],
          'ignore_missing': 'true',
        },
      },
    ],
    'depends_on': [],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
      ],
    },
  }

def notification(config):
  steps = [{
    'name': 'notify',
    'image': 'plugins/slack',
    'settings': {
      'webhook': {
        'from_secret': 'private_rocketchat',
      },
      'channel': 'builds',
    },
    'when': {
      'status': [
        'success',
        'failure',
      ],
    },
  }]

  downstream = [{
    'name': 'downstream',
    'image': 'plugins/downstream',
    'settings': {
      'token': {
        'from_secret': 'drone_token',
      },
      'server': 'https://drone.owncloud.com',
      'repositories': config['trigger'],
    },
    'when': {
      'status': [
        'success',
      ],
    },
  }]

  if config['trigger']:
    steps = downstream + steps

  return {
    'kind': 'pipeline',
    'type': 'docker',
    'name': 'notification',
    'platform': {
      'os': 'linux',
      'arch': 'amd64',
    },
    'clone': {
      'disable': True,
    },
    'steps': steps,
    'depends_on': [],
    'trigger': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
      ],
      'status': [
        'success',
        'failure',
      ],
    },
  }

def dryrun(config):
  return [{
    'name': 'dryrun',
    'image': 'plugins/docker',
    'settings': {
      'dry_run': True,
      'tags': config['tags'],
      'dockerfile': '%s/Dockerfile.%s' % (config['path'], config['arch']),
      'repo': 'owncloudci/%s' % config['repo'],
      'context': config['path'],
    },
    'when': {
      'ref': [
        'refs/pull/**',
      ],
    },
  }]

def publish(config):
  return [{
    'name': 'publish',
    'image': 'plugins/docker',
    'settings': {
      'username': {
        'from_secret': 'public_username',
      },
      'password': {
        'from_secret': 'public_password',
      },
      'tags': config['tags'],
      'dockerfile': '%s/Dockerfile.%s' % (config['path'], config['arch']),
      'repo': 'owncloudci/%s' % config['repo'],
      'context': config['path'],
      'pull_image': False,
    },
    'when': {
      'ref': [
        'refs/heads/master',
        'refs/tags/**',
      ],
    },
  }]

def steps(config):
  return dryrun(config) + publish(config)
