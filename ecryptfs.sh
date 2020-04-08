#!/bin/bash
#
# This script is originally from:
# https://gist.githubusercontent.com/mzpqnxow/ce8fbfb6fe10e5e722425ecd1d80d506/raw/8bf946689d55db787e9c07e58c051a1d4cba2ed6/build-ecryptfs-debian-buster.sh
#

set -e

# As of 11/24/2019, Debian still can't get it together with ecryptfs-utils so there
# is no longer an ecryptfs-utils in the apt repositories, removing the ability for
# a user to use ecryptfs at all, unless they build from source and manually configure
# the system
#
# Before using this, please see the status of the bugreport:
#
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=765854
#
# Basically, Debian removed the apt package until this bug can be fixed. The problem
# was that private ecryptfs mounts were not being unmounted on logout, almost completely
# voiding the value of the functionality :<
# 
# If the bug is not yet fixed, you can use this script/guide to get ecryptfs per-user
# home directory encryption working
#
# This is probably a bit broader than necessary, but many of these are requirements to
# build ecryptfs-utils. Others, such as rsync and lsof are included as they are required
# for ecryptfs-migrate-home at runtime
DEPS="gpgv2 intltool keyutils libgpgme-dev libkeyutils-dev libnss3-dev libpam-dev \
      libpam-pkcs11 libpkcs11-helper1-dev libtspi-dev python2-dev python3-dev \
      rsync lsof build-essential"
# You can use /opt/ecryptfs or something if you don't want it in your root
# Using something other than /usr may cause issues due to assumptions made in this script!
PREFIX=/usr
apt-get update
echo -n 'Press enter to install dependencies via apt-get ...'
apt-get install $DEPS
cd /usr/src
echo 'WARN: The source package is downloaded from the distribution site, but no signature check is performed!'
echo -n 'Press enter to download version 111 of ecryptfs-utils from the distribution site ...'
read x
# Change the link to a different version if desired, but other versions are untested
# This is the latest version as of 2019-11-24 ...
rm -rf ecryptfs-utils*
wget https://launchpad.net/ecryptfs/trunk/111/+download/ecryptfs-utils_111.orig.tar.gz
# You should check the signature here, probably
tar -xvzf ecryptfs-utils_111.orig.tar.gz
cd ecryptfs-utils-111
echo 'NOTE: if the following step fails, you may need to apt-get some additional dependencies'
echo -n 'Press enter to configure, build and install ecryptfs-utils from source ...'
read x
./configure LIBS='-lkeyutils -lnss3 -lnssutil3' --prefix=/usr KEYUTILS_LIBS='-lnss3 -lnssutil3' NSS_CFLAGS='-I/usr/include/nss -I/usr/include/nspr'
# This patch is from:
# https://code.launchpad.net/~jelle-vdwaa/ecryptfs/ecryptfs/+merge/319746
cat <<EOF | patch -p0
--- src/key_mod/ecryptfs_key_mod_openssl.c	2013-10-25 19:45:09 +0000
+++ src/key_mod/ecryptfs_key_mod_openssl.c	2017-06-02 18:27:28 +0000
@@ -41,6 +41,7 @@
 #include <stdlib.h>
 #include <unistd.h>
 #include <libgen.h>
+#include <openssl/bn.h>
 #include <openssl/pem.h>
 #include <openssl/rsa.h>
 #include <openssl/err.h>
@@ -55,6 +56,19 @@
 	char *passphrase;
 };
 
+#if OPENSSL_VERSION_NUMBER < 0x10100000L
+static void RSA_get0_key(const RSA *r,
+                 const BIGNUM **n, const BIGNUM **e, const BIGNUM **d)
+{
+   if (n != NULL)
+       *n = r->n;
+   if (e != NULL)
+       *e = r->e;
+   if (d != NULL)
+       *d = r->d;
+}
+#endif
+
 static void
 ecryptfs_openssl_destroy_openssl_data(struct openssl_data *openssl_data)
 {
@@ -142,6 +156,7 @@
 {
 	int len, nbits, ebits, i;
 	int nbytes, ebytes;
+	const BIGNUM *key_n, *key_e;
 	unsigned char *hash;
 	unsigned char *data = NULL;
 	int rc = 0;
@@ -152,11 +167,13 @@
 		rc = -ENOMEM;
 		goto out;
 	}
-	nbits = BN_num_bits(key->n);
+	RSA_get0_key(key, &key_n, NULL, NULL);
+	nbits = BN_num_bits(key_n);
 	nbytes = nbits / 8;
 	if (nbits % 8)
 		nbytes++;
-	ebits = BN_num_bits(key->e);
+	RSA_get0_key(key, NULL, &key_e, NULL);
+	ebits = BN_num_bits(key_e);
 	ebytes = ebits / 8;
 	if (ebits % 8)
 		ebytes++;
@@ -179,11 +196,13 @@
 	data[i++] = '\02';
 	data[i++] = (nbits >> 8);
 	data[i++] = nbits;
-	BN_bn2bin(key->n, &(data[i]));
+	RSA_get0_key(key, &key_n, NULL, NULL);
+	BN_bn2bin(key_n, &(data[i]));
 	i += nbytes;
 	data[i++] = (ebits >> 8);
 	data[i++] = ebits;
-	BN_bn2bin(key->e, &(data[i]));
+	RSA_get0_key(key, NULL, &key_e, NULL);
+	BN_bn2bin(key_e, &(data[i]));
 	i += ebytes;
 	SHA1(data, len + 3, hash);
 	to_hex(sig, (char *)hash, ECRYPTFS_SIG_SIZE);
@@ -278,7 +297,9 @@
 	BIO *in = NULL;
 	int rc;
 
+	#if OPENSSL_VERSION_NUMBER < 0x10100000L
 	CRYPTO_malloc_init();
+	#endif
 	ERR_load_crypto_strings();
 	OpenSSL_add_all_algorithms();
 	ENGINE_load_builtin_engines();

=== modified file 'src/key_mod/ecryptfs_key_mod_pkcs11_helper.c'
--- src/key_mod/ecryptfs_key_mod_pkcs11_helper.c	2013-10-25 19:45:09 +0000
+++ src/key_mod/ecryptfs_key_mod_pkcs11_helper.c	2017-06-02 18:27:28 +0000
@@ -41,6 +41,7 @@
 #include <errno.h>
 #include <stdlib.h>
 #include <unistd.h>
+#include <openssl/bn.h>
 #include <openssl/err.h>
 #include <openssl/pem.h>
 #include <openssl/x509.h>
@@ -77,6 +78,19 @@
 typedef const unsigned char *__pkcs11_openssl_d2i_t;
 #endif
 
+#if OPENSSL_VERSION_NUMBER < 0x10100000L
+static void RSA_get0_key(const RSA *r,
+                 const BIGNUM **n, const BIGNUM **e, const BIGNUM **d)
+{
+   if (n != NULL)
+       *n = r->n;
+   if (e != NULL)
+       *e = r->e;
+   if (d != NULL)
+       *d = r->d;
+}
+#endif
+
 /**
  * ecryptfs_pkcs11h_deserialize
  * @pkcs11h_data: The deserialized version of the key module data;
@@ -282,7 +296,11 @@
 		goto out;
 	}
 	
+	#if OPENSSL_VERSION_NUMBER < 0x10100000L
 	if (pubkey->type != EVP_PKEY_RSA) {
+	#else
+	if (EVP_PKEY_base_id(pubkey) != EVP_PKEY_RSA) {
+	#endif
 		syslog(LOG_ERR, "PKCS#11: Invalid public key algorithm");
 		rc = -EIO;
 		goto out;
@@ -318,6 +336,7 @@
 	int nbytes, ebytes;
 	char *hash = NULL;
 	char *data = NULL;
+	const BIGNUM *rsa_n, *rsa_e;
 	int rc;
 
 	if ((rc = ecryptfs_pkcs11h_get_public_key(&rsa, blob))) {
@@ -331,11 +350,13 @@
 		rc = -ENOMEM;
 		goto out;
 	}
-	nbits = BN_num_bits(rsa->n);
+	RSA_get0_key(rsa, &rsa_n, NULL, NULL);
+	nbits = BN_num_bits(rsa_n);
 	nbytes = nbits / 8;
 	if (nbits % 8)
 		nbytes++;
-	ebits = BN_num_bits(rsa->e);
+	RSA_get0_key(rsa, NULL, &rsa_e, NULL);
+	ebits = BN_num_bits(rsa_e);
 	ebytes = ebits / 8;
 	if (ebits % 8)
 		ebytes++;
@@ -358,11 +379,13 @@
 	data[i++] = '\02';
 	data[i++] = (char)(nbits >> 8);
 	data[i++] = (char)nbits;
-	BN_bn2bin(rsa->n, &(data[i]));
+	RSA_get0_key(rsa, &rsa_n, NULL, NULL);
+	BN_bn2bin(rsa_n, &(data[i]));
 	i += nbytes;
 	data[i++] = (char)(ebits >> 8);
 	data[i++] = (char)ebits;
-	BN_bn2bin(rsa->e, &(data[i]));
+	RSA_get0_key(rsa, NULL, &rsa_e, NULL);
+	BN_bn2bin(rsa_e, &(data[i]));
 	i += ebytes;
 	SHA1(data, len + 3, hash);
 	to_hex(sig, hash, ECRYPTFS_SIG_SIZE);
EOF
make -j && make install
cd
echo 'The ecryptfs-utils are now installed on your system, but there is more to do'
echo 'Step 1 - fix pam so that mounting is automated'
echo -n '  Add auth required pam_ecryptfs unwrap to pam common-auth? Enter to continue... '
read x
grep pam_ecryptfs.so /etc/pam.d/common-auth || echo 'auth    required        pam_ecryptfs.so unwrap' >> /etc/pam.d/common-auth
echo -n '  Add auth optional pam_ecryptfs unwrap to /etc/pam.d/common-session? Enter to continue... '
read x
grep pam_ecryptfs.so /etc/pam.d/common-session || echo 'session optional        pam_ecryptfs.so unwrap' >> /etc/pam.d/common-session
echo 'Done fixing PAM. If you want configuration/migration of users to use ecryptfs to work, it is necessary'
echo 'to add the setuid bit to /usr/sbin/mount.ecryptfs_private'
echo 'Step 2 - fix permissions on mount.ecryptfs_private so setreuid succeeds at runtime'
echo -n '  Use chmod to set setuid bit on mount.ecryptfs_private? Enter to continue ... '
read x
chmod u+s /usr/sbin/mount.ecryptfs_private
echo 'Done. Consider the following manual steps for increased security:'
echo '  1. Create a group called "ecryptfs" using "groupadd ecryptfs"'
echo '  2. Place "trusted" users who should be allowed to user ecryptfs in that group by editing /etc/group'
echo '  3. Use "chmod 4750 && chgrp /usr/sbin/mount.ecryptfs_private ecryptfs" to protect the mount app'
echo
echo 'Installation and configuration complete!'
echo 'Try using ecryptfs-migrate-home to migrate a user to an encrypted home directory' 
echo 'Make sure you test to ensure things are working, this is not official documentation!'
