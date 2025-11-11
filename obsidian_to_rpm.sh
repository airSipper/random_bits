# REPACKAGE OBSIDIAN FROM .DEB to .RPM

# as unpriv user, download .deb file
wget -P /tmp https://github.com/obsidianmd/obsidian-releases/releases/download/v1.9.14/obsidian_1.9.14_amd64.deb

# Validate hash of the .deb from https://github.com/obsidianmd/obsidian-releases/releases
# obsidian_1.9.14_amd64.deb 
# sha256:d1ad758b1977a34ff7d0c906f11e0e88aa0a940fa4a22b83d357dab8ddd32d37
sha256sum /tmp/obsidian_1.9.14_amd64.deb

# prelim - loosen rpm build failure restrictions, build will fail otherwise
sudo -i
cat << EOF >> /etc/rpm/macros
%_unpackaged_files_terminate_build      0
%_binaries_in_noarch_packages_terminate_build   0

EOF

# create build dir and stage build
mkdir -p ~/rpmbuild; cd ~/rpmbuild/
alien -r -g -v /tmp/obsidian_1.9.14_amd64.deb -c

# modify the spec file, build will fail without a summary
sed -i 's/Summary\:/Summary\:\ Obsidian\-\ repackaged\ by\ ABC\ for\ XYZ/' obsidian-1.9.14/obsidian-1.9.14-2.spec

# build the package
rpmbuild --target=x86_64 --buildroot $PWD  -bb obsidian-1.9.14/obsidian-1.9.14-2.spec

# rpm should be available in ~/rpmbuild/, gpgcheck may be ignored for command line install
yum install -y ~/rpmbuild/obsidian-1.9.14-2.x86_64.rpm

# cleanup
rm -f /tmp/obsidian_1.9.14_amd64.deb
# cd ~/; rm -rf ~/rpmbuild/


# Sign the new package
# create a key, fill in some informatino
gpg --full-gen-key
#GnuPG needs to construct a user ID to identify your key.
#...
#Real name: Cyber Operations Package Management
#Email address: admin@domain.example.com
#Comment: RPM Signing Key

# export the key so it can be imported into rpm, must match real name set above
gpg --export -a 'Cyber Operations Package Management' > ~/signing_key

# import the key into rpm
rpm --import ~/signing_key

# add the key name to the signing macro
cat << EOF >> ~/.rpmmacros
%_signature gpg
%_gpg_name Cyber Operations Package Management
%_gpgbin /usr/bin/gpg2

EOF

# Validate that the package is not already signed
rpm -qip ~/rpmbuild/obsidian-1.9.14-2.x86_64.rpm | grep Signature

# sign the rpm
rpm --addsign ~/rpmbuild/obsidian-1.9.14-2.x86_64.rpm

# validate that the package is now signed
rpm -qip ~/rpmbuild/obsidian-1.9.14-2.x86_64.rpm | grep Signature
