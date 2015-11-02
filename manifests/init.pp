# == Class: nomadproject
#
# Full description of class nomadproject here.
#
# === Parameters
#
# Document parameters here.
#
# [*version*]
#   Version of nomad to install defaults to 0.1.2
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
# === Authors
#
# Chris Mague <github@mague.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class nomadproject (
  $user = 'root',
  $group = 'root',
  $version = '0.1.2',
  $bin_dir = '/usr/bin',
  $data_dir = '/opt/nomad',
  $download_url = "https://releases.hashicorp.com/nomad/${version}/nomad_${version}_${::os}_${::arch}.zip"
  ){

  file { $data_dir:
    ensure => 'directory',
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  if $::operatingsystem != 'darwin' {
    ensure_packages(['unzip'])
  }

  staging::file { 'nomad.zip':
    source => $nomad::download_url
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

}
