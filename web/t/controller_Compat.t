use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Sophie' }
BEGIN { use_ok 'Sophie::Controller::Compat' }

ok( request('/viewrpm')->is_redirect, 'Request should succeed' );
ok( request('/viewrpm/azerty')->is_redirect, 'Request should succeed' );
ok( request('/distrib/Mandriva,cooker,i586/azerty')->is_redirect, 'Request should succeed' );
done_testing();
