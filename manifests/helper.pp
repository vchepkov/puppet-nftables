# manage a helper
define nftables::helper (
  # lint:ignore:parameter_documentation
  String $content,
  Pattern[/^(ip|ip6|inet)-[a-zA-Z0-9_]+$/] $table = 'inet-filter',
  Pattern[/^[a-zA-Z0-9_][A-z0-9_-]*$/] $helper = $title,
  # lint:endignore
) {
  $concat_name = "nftables-${table}-helper-${helper}"

  concat {
    $concat_name:
      path           => "/etc/nftables/puppet-preflight/${table}-helper-${helper}.nft",
      owner          => root,
      group          => root,
      mode           => $nftables::default_config_mode,
      ensure_newline => true,
      require        => Package['nftables'],
  } ~> Exec['nft validate'] -> file {
    "/etc/nftables/puppet/${table}-helper-${helper}.nft":
      ensure => file,
      source => "/etc/nftables/puppet-preflight/${table}-helper-${helper}.nft",
      owner  => root,
      group  => root,
      mode   => $nftables::default_config_mode,
  } ~> Service['nftables']

  concat::fragment {
    default:
      target => $concat_name;
    "${concat_name}-header":
      order   => '00',
      content => "# Start of fragment order:00 ${helper} header\nct helper ${helper} {";
    "${concat_name}-body":
      order   => '98',
      content => $content;
    "${concat_name}-footer":
      order   => '99',
      content => "# Start of fragment order:99 ${helper} footer\n}";
  }
}
