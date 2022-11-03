# See virtualbox versions: https://download.virtualbox.org/virtualbox
$local:VARIANTS_MATRIX = @(
    @{
        package = 'packer'
        package_version = '1.7.7'
        distro = 'ubuntu'
        distro_version = '20.04'
        subvariants = @(
            @{ components = @( 'sops' ); tag_as_latest = $true }
            @{ components = @( 'sops', 'virtualbox-7.0.2' ) }
            @{ components = @( 'sops', 'virtualbox-6.1.40' ) }
            @{ components = @( 'sops', 'virtualbox-6.1.26' ) }
        )
    }
    @{
        package = 'packer'
        package_version = '1.7.7'
        distro = 'ubuntu'
        distro_version = '18.04'
        subvariants = @(
            @{ components = @( 'sops', 'virtualbox-6.0.24' ) }
        )
    }
    @{
        package = 'packer'
        package_version = '1.7.7'
        distro = 'ubuntu'
        distro_version = '16.04'
        subvariants = @(
            @{ components = @( 'sops', 'virtualbox-5.2.44' ) }
        )
    }
)

$VARIANTS = @(
    foreach ($variant in $VARIANTS_MATRIX){
        foreach ($subVariant in $variant['subvariants']) {
            @{
                # Metadata object
                _metadata = @{
                    package_version = $variant['package_version']
                    distro = $variant['distro']
                    distro_version = $variant['distro_version']
                    platforms = 'linux/amd64'
                    components = $subVariant['components']
                }
                # Docker image tag. E.g. '1.7.7-virtualbox-ubuntu-18.04'
                tag = @(
                        $variant['package_version']
                        $subVariant['components'] | ? { $_ }
                        $variant['distro']
                        $variant['distro_version']
                ) -join '-'
                tag_as_latest = if ( $subVariant.Contains('tag_as_latest') ) {
                                    $subVariant['tag_as_latest']
                                } else {
                                    $false
                                }
            }
        }
    }
)

# Docker image variants' definitions (shared)
$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                common = $true
                includeHeader = $false
                includeFooter = $false
                passes = @(
                    @{
                        variables = @{}
                    }
                )
            }
        }
    }
}
