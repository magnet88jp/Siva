package Siva::Schema::TestCase;

# Created by DBIx::Class::Schema::Loader v0.03007 @ 2010-04-18 18:10:10

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("test_case");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('test_case_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "name",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "filename",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "tags",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "explanation",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "suite_case_maps",
  "SuiteCaseMap",
  { "foreign.test_case_id" => "self.id" },
);
__PACKAGE__->has_many(
  "case_command_maps",
  "CaseCommandMap",
  { "foreign.test_case_id" => "self.id" },
);

1;

