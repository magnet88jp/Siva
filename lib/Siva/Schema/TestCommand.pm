package Siva::Schema::TestCommand;

# Created by DBIx::Class::Schema::Loader v0.03007 @ 2010-04-18 18:10:10

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("test_command");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('test_command_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "command",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "target",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "value",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "case_command_maps",
  "CaseCommandMap",
  { "foreign.test_command_id" => "self.id" },
);

1;

