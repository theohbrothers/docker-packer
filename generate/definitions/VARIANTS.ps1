
# Docker image variants' definitions
$VARIANTS = @(
    @{
        _metadata = @{
            package_version = '1.7.7'
            distro = 'ubuntu'
            distro_version = '20.04'
            platforms = 'linux/amd64'
            components = @( 'sops' )
        }
        tag = '1.7.7-sops-ubuntu-20.04'
        tag_as_latest = $true
    }
    @{
        _metadata = @{
            package_version = '1.7.7'
            distro = 'ubuntu'
            distro_version = '20.04'
            platforms = 'linux/amd64'
            components = @( 'sops', 'virtualbox-6.1.26' )
        }
        tag = '1.7.7-sops-virtualbox-6.1-ubuntu-20.04'
    }
    @{
        _metadata = @{
            package_version = '1.7.7'
            distro = 'ubuntu'
            distro_version = '18.04'
            platforms = 'linux/amd64'
            components = @( 'sops' )
        }
        tag = '1.7.7-sops-ubuntu-18.04'
    }
    @{
        _metadata = @{
            package_version = '1.7.7'
            distro = 'ubuntu'
            distro_version = '18.04'
            platforms = 'linux/amd64'
            components = @( 'sops', 'virtualbox-6.1.26' )
        }
        tag = '1.7.7-sops-virtualbox-6.1-ubuntu-18.04'
    }
)

# Docker image variants' definitions (shared)
$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                common = $true
                passes = @(
                    @{
                        variables = @{}
                    }
                )
            }
        }
    }
}
