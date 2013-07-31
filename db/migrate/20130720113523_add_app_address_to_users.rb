class AddAppAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :app_address, :string, :default => "127.0.0.1:3000"
  end
end
