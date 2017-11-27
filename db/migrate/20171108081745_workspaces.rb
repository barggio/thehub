class Workspaces < ActiveRecord::Migration[5.1]
  def change
    create_table :workspaces do |t|
      t.string :wid , null: false
      t.string :description , null: false
      t.string :userid , null: false
      t.integer :isshared  , null: false, default: false
      t.timestamps
    end    
  end
end
