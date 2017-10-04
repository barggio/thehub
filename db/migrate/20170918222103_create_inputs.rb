class CreateInputs < ActiveRecord::Migration[5.1]
  def change
    create_table :inputs do |t|
      t.string :type , null: false
      t.string :name , null: false
      t.string :content , null: false
      t.string :user  , null: false
      t.timestamps
    end
  end
end
