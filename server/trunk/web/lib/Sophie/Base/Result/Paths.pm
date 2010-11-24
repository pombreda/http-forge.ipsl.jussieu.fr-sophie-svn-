package Sophie::Base::Result::Paths;

use strict;
use warnings;
use base qw(DBIx::Class::Core);

__PACKAGE__->table('d_path');
__PACKAGE__->add_columns(qw/d_path_key path added updated/);
__PACKAGE__->set_primary_key('d_path_key');
#__PACKAGE__->belongs_to(media => 'Sophie::Base::Result::Medias', 'media');
__PACKAGE__->has_many(MediasPaths => 'Sophie::Base::Result::MediasPaths', 'd_path');
__PACKAGE__->has_many(Rpmfiles => 'Sophie::Base::Result::RpmFile', 'd_path');


1;