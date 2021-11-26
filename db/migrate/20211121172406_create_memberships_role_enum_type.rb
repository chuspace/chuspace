# frozen_string_literal: true

class CreateMembershipsRoleEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE membership_role_enum_type AS ENUM ('writer', 'editor', 'manager', 'owner', 'subscriber');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE membership_role_enum_type;
    SQL
  end
end
