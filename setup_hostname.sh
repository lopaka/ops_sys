#!/usr/bin/sudo /bin/bash

set -ex

echo "DEBUG-------------------"
cat ./attachements/blah.txt
cat ./different_name/arg.txt
echo "DEBUG^^^^^^^^^^^^^^^^^^^"

#
# Drop to lower case, since hostnames should be lc anyway.
#
HOSTNAME=$(echo $HOSTNAME | tr "[:upper:]" "[:lower:]")

#
# Support optional server namspacing
# And store the namespace in /etc/namespace
#
# Example: "crimson:broker1-1.rightscale.com"
#
if (echo $HOSTNAME | grep -q ":"); then
  namespace=`echo $HOSTNAME | cut -d: -f1`
  HOSTNAME=`echo $HOSTNAME | cut -d: -f2`
  echo $namespace > /etc/namespace
  echo "Found namespaced hostname: NAMESPACE='$namespace' HOSTNAME='$HOSTNAME'"
fi

# this is part of my featue branch

#
# Check for a numeric suffix (like in a server array)
# example:  array name #1
#
if [ $( echo $HOSTNAME | grep "#" -c ) -gt 0 ]; then
  numeric_suffix=$( echo $HOSTNAME | cut -d'#' -f2 )  
else
  # no suffix
  numeric_suffix=""
fi

# Strip off "znew", or "zold" prepend.
HOSTNAME=${HOSTNAME#znew}
HOSTNAME=${HOSTNAME#zold}

# Strip off a leading "-"'s or leading whitespace, if there is any.
HOSTNAME=${HOSTNAME##*( |-)}

# Clean up the hostname, so we can put labels after hostnames
# with no problems (like 'sketchy1-10.rightscale.com MY COMMENT')
HOSTNAME=$(echo $HOSTNAME | cut -d' ' -f 1)

# Underscores are illegal in hostnames, so change them to dashes.
HOSTNAME=$(echo $HOSTNAME | sed "s/_/-/g")

# Append a numeric suffix to the sname, if we have one.
if [ ! -z $numeric_suffix ]; then
  echo "Appending array suffix $numeric_suffix to the sname"
  sname=$(echo $HOSTNAME | cut -d'.' -f 1)
  dname=${HOSTNAME#"$sname"}

  HOSTNAME="$sname-$numeric_suffix$dname"
else 
  echo "No suffix found, not appending anything."
fi

# Force the hostname to be valid according to
# the rules here:
# http://en.wikipedia.org/wiki/Hostname
# With the following expceptions:
# 1) We allow ending hostnames in a digit
# 2) We allow dots in the hostname
# Lower-case the hostname
HOSTNAME=$(echo $HOSTNAME | tr "A-Z" "a-z")
# If any chars are not a digit, A-Z, hyphen or dot, replace with hyphen.
HOSTNAME=$(echo $HOSTNAME | sed "s/[^0-9A-Za-z.]/-/g")
# If the hostname is > 63 chars, truncate it.
HOSTNAME=$(echo $HOSTNAME | sed 's/^\(.\{63\}\).*/\1/')
# If the hostname ends in a hyphen, replace it with "x"
HOSTNAME=$(echo $HOSTNAME | sed 's/\-$/x/')

echo "setting hostname to: $HOSTNAME"
hostname $HOSTNAME

# make sure $HOSTNAME is valid, or RightLink/Ohai/Chef will crash
# it doesn't have to point to our IP, it just has to resolve.
(ip_addr=$(dig $HOSTNAME +short)) || true

if [ -z "$ip_addr" ]; then
  echo "WARNING!  The hostname you're attempting to use is NOT valid!"
  echo "Putting a local lookup in /etc/hosts as a work around."
  echo -e "\n127.0.0.1  $HOSTNAME\n" >> /etc/hosts 
fi

# Set the default hostname, so it'll stick even after a DHCP update
echo "$HOSTNAME" > /etc/hostname

# Fix the 127.0.1.1 record, so ubuntu sudo will still work, in case we ever want to use it.
short_hostname=$(echo $HOSTNAME | cut -d'.' -f1)
sed -i "s%^127.0.1.1.*%127.0.1.1 $HOSTNAME $short_hostname%" /etc/hosts
