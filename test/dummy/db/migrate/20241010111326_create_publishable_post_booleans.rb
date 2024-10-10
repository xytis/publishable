class CreatePublishablePostBooleans < ActiveRecord::Migration[7.2]
  def change
    create_table :publishable_post_booleans do |t|
      t.boolean :published

      t.timestamps
    end
  end
end
