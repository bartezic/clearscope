require 'csv'

class CreatePoints < ActiveRecord::Migration[7.1]
  def change
    create_table :points do |t|
      t.datetime :created_at, null: false
      t.integer :magnitude, null: false
    end
    add_index :points, :created_at

    reversible do |dir|
      dir.up do
        attrs = CSV.read("db/points.csv").map do |row|
          { created_at: Time.at(row[0].to_i), magnitude: row[1] }
        end
        Point.insert_all(attrs)
      end
    end
  end
end