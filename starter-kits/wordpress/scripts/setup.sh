#!/bin/sh

set -e

# Ensure MySQL connection is up before proceeding.
until mysql -uwordpress -pwordpress -hdb wordpress; do
    >&2 echo "Waiting for MySQL ..."
    sleep 1
done

# Configure WordPress
echo "Configuring WordPress..."
wp config create --dbname=$WORDPRESS_DB_NAME --dbuser=$WORDPRESS_DB_USER --dbpass=$WORDPRESS_DB_PASSWORD --dbhost=$WORDPRESS_DB_HOST --extra-php <<PHP
// This allows the WordPress site to run securly behind the ups-dock reverse proxy
if ( strpos( \$_SERVER['HTTP_X_FORWARDED_PROTO'], 'https' ) !== false ) {
    \$_SERVER['HTTPS'] = 'on';
}
define( 'WP_DEBUG', true );
PHP

# Run WP install if it's not already installed.
if ! $(wp core is-installed); then
	wp core install \
		--url="$WORDPRESS_URL" \
		--title="$WORDPRESS_TITLE" \
		--admin_user="$WORDPRESS_ADMIN_USER" \
		--admin_email="$WORDPRESS_ADMIN_EMAIL" \
		--admin_password="$WORDPRESS_ADMIN_PASSWORD"

	# Activate this theme.
	wp theme activate "$WORDPRESS_THEME_NAME"
fi