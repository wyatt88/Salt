#mfs.tar.gz
mfs_source:
  file.managed:
    - name: /tmp/moosefs-2.0.80-1.tar.gz
    - unless: test -e /tmp/moosefs-2.0.80-1.tar.gz
    - source: salt://mfs/files/moosefs-2.0.80-1.tar.gz

#extract

extract_mfs:
  cmd.run:
    - cwd: /tmp
    - names:
      - tar zxvf moosefs-2.0.80-1.tar.gz
    - unless: test -d /tmp/moosefs-2.0.80
    - require:
      - file: mfs_source


#user

mfs_user:
  user.present:
    - name: mfs
    - uid: 1502
    - createhome: False
    - gid_from_name: True
    - shell: /sbin/nologin

#mfs_pkgs

mfs_pkg:
  pkg.installed:
    - pkgs:
      - gcc

#mfs_compile
mfs_compile:
  cmd.run:
    - cwd: /tmp/moosefs-2.0.80
    - names:
      - ./configure --prefix=/usr/local/mfs --with-default-user=mfs --with-default-group=mfs
      - make
      - make install
    - require:
      - cmd: extract_mfs
      - pkg:  mfs_pkg
    - unless: test -d /usr/local/mfs

#cache_dir
cache_dir:
  cmd.run:
    - names:
      - chown -R mfs.mfs /usr/local/mfs/
    - unless: test -d /usr/local/mfs/
    - require:
      - cmd: mfs_compile
