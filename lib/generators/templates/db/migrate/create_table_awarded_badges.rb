class CreateTableAwardedBadges < ActiveRecord::Migration
  def change
    create_table :awarded_badges do |t|
      t.integer :awardee_id  
      t.string  :awardee_type  
      t.string  :badge_code
      t.integer :level
      t.integer :awardable_id
      t.integer :awardable_type
      t.timestamps
    end

    add_index :awarded_badges, [:awardee_id, :awardee_type, :badge_code, :level], name: 'strong_badge', :unique => true
    add_index :awarded_badges, [:awardable_id, :awardable_type]
  end
end
