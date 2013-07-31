class CreateTestRuns < ActiveRecord::Migration
  def up
    create_table :test_runs do |t|
      t.timestamps
      t.references :user
      t.integer :score
      t.string :status
      t.text :output
    end

    add_index :test_runs, [:user_id, :created_at]
    add_index :test_runs, [:user_id, :score]
    add_index :test_runs, [:user_id, :status]
  end

  def down
    remove_table :test_runs
  end
end
