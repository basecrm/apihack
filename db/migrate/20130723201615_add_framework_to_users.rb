class AddFrameworkToUsers < ActiveRecord::Migration
  def change
    add_column :users, :framework, :string, :default => "phpMyAdmin"
  end
end
