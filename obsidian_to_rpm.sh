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
