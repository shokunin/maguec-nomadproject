# == Class: nomadproject
#
# Full description of class nomadproject here.
#
# === Parameters
#
# Document parameters here.
#
# [*version*]
#   Version of nomad to install defaults to 0.2.1
#
# [*user*]
#   Run user defaults to root
#
# [*group*]
#   Run group defaults to root
#
# [*data_dir*]
#   Where to store the nomad data defaults to /opt/nomad
#
# [*bin_dir*]
#   Where to install the nomad binary
#
# [*bind_interface*]
#   bind to a specific interface
#
# === Authors
#
# Chris Mague <github@mague.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class nomadproject (
  $user             = 'root',
  $group            = 'root',
  $version          = '0.2.1',
  $port             = '4647',
  $bin_dir          = '/usr/bin',
  $data_dir         = '/opt/nomad',
  $nomad_role       = 'client',
  $datacenter       = 'nomad',
  $region           = 'nomad',
  $bind_interface   = '',
  $bootstrap_expect = 1,
  $server_list      = [],
  $config_hash      = {},
  ){

  $config_default = {
    'data_dir'   => $data_dir,
    'region'     => $region,
    'datacenter' => $datacenter,
    'name'       => $::hostname,
    'bind_addr'  => $::ipaddress,
  }

  if ($nomad_role == 'client') and ( size($server_list) == 0 ) {
    notify { "WARNING: Set as ${nomad_role}, but no servers set => ${server_list}": }
  }


  validate_hash($config_hash)
  $final_sets = merge($config_default, $config_hash)

  $os = downcase($::kernel)
  $download_url = "https://releases.hashicorp.com/nomad/${version}/nomad_${version}_${os}_${::architecture}.zip"

  file { $data_dir:
    ensure => 'directory',
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  staging::file { 'nomad.zip':
    source => $download_url
  } ->
  staging::extract { 'nomad.zip':
    target  => $bin_dir,
    creates => "${bin_dir}/nomad",
  } ->
  file { "${bin_dir}/nomad":
    owner => 'root',
    group => 0,
    mode  => '0555',
  }

  file { '/etc/nomad.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('nomadproject/nomad.erb'),
    require => File["${bin_dir}/nomad"],
    notify  => Service['nomad'],
  }

  file { '/etc/init/nomad.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0444',
    content => template('nomadproject/upstart.erb'),
  }

  service { 'nomad' :
    ensure  => running,
    enable  => true,
    require => File['/etc/nomad.conf', '/etc/init/nomad.conf'],
  }

}
