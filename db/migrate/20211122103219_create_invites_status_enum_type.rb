# frozen_string_literal: true

class CreateInvitesStatusEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE invite_status_enum_type AS ENUM ('pending', 'expired', 'joined');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE invite_status_enum_type;
    SQL
  end
end
