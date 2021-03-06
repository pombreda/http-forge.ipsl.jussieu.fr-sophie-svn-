package Sophie::Base::Result::Rpms;

use strict;
use warnings;
use base qw(DBIx::Class::Core);

__PACKAGE__->table('rpms');
__PACKAGE__->add_columns(qw/pkgid summary description issrc name evr arch header/);
__PACKAGE__->set_primary_key(qw/pkgid/);
__PACKAGE__->has_many(RpmFile => 'Sophie::Base::Result::RpmFile', 'pkgid');
__PACKAGE__->has_many(Deps => 'Sophie::Base::Result::Deps', 'pkgid');
__PACKAGE__->has_many(Files => 'Sophie::Base::Result::Files', 'pkgid');
__PACKAGE__->has_many(BinFiles => 'Sophie::Base::Result::BinFiles', 'pkgid');
__PACKAGE__->has_many(SrcFiles => 'Sophie::Base::Result::SrcFiles', 'pkgid');
__PACKAGE__->has_many(Tags => 'Sophie::Base::Result::Tags', 'pkgid');

__PACKAGE__->add_relationship(  DesktopFiles => 'Sophie::Base::Result::DesktopFiles',
                              { 'foreign.pkgid' => 'self.pkgid' });

1;
