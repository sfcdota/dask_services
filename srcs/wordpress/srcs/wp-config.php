<?php
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** MySQL database username */
define( 'DB_USER', 'cbach' );

/** MySQL database password */
define( 'DB_PASSWORD', 'pass' );

/** MySQL hostname */
define( 'DB_HOST', 'mysql' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'X*-b) j;ivde1BL<ll8]s]z5i#MSQj_4Ywwq`f]O|Pa^1EK=5+|0?yNj_d[} j{+' );
define( 'SECURE_AUTH_KEY',  'w+_1=ZTs*71zs>5{g;H9,f(%=3>XB~>v+-H.x=X439-:8b3aLI>u**?F!ox0,o|0' );
define( 'LOGGED_IN_KEY',    'A|]pJ%Jb0!0mxH+[7PhN,8rGnK>k/a{B2QUe7Z`7D|.Z~uc^&1Ss8)FQ y$)&Tng' );
define( 'NONCE_KEY',        'v|qUQP-|LV$PotK`hH4Pg3d*G/iQK1;A.>aV$g}yPEEw-4_5f#T(o FpryfS.5N6' );
define( 'AUTH_SALT',        'c*jpQE`je<+&ya+UUuq-Fj:8)K-N-$.~Wqf~C*f+x|uR%hYGs;u&5(4kba<S{b6z' );
define( 'SECURE_AUTH_SALT', 'O^4}x|ZHC{+w*_b27Rp7$LGE?<Q=-(p=1W@!7-r>v>w~R5KE|xY(!e:/Duj55N-B' );
define( 'LOGGED_IN_SALT',   'C-]ai6W+lDklQu^uydZx0WLrDweitGy,DIuUjkT@/70&3-BcSA^j|PDlM%PP^Uuw' );
define( 'NONCE_SALT',       'O=cpSAH82}D8{vXiy3o)|A$SCaN^VlC^r]Pl|!=aDr>ZVU>cB|#>SqSx;TRJNrwd' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
