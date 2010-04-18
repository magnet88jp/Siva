package Siva::Schema::CaseCommandMap;

# Created by DBIx::Class::Schema::Loader v0.03007 @ 2010-04-18 18:10:10

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("case_command_map");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('case_command_map_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "test_case_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "test_command_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "map_order",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("test_case_id", "TestCase", { id => "test_case_id" });
__PACKAGE__->belongs_to("test_command_id", "TestCommand", { id => "test_command_id" });

1;

