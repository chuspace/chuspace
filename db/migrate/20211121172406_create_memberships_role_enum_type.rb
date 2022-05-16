# frozen_string_literal: true

class CreateMembershipsRoleEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE membership_role_enum_type AS ENUM (#{RolesConfig.to_enum.keys.map { |role| "'#{role}'" }.join(',') });
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE membership_role_enum_type;
    SQL
  end
end
