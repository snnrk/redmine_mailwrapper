class CreateMailwrapperSenders < ActiveRecord::Migration
  def self.up
    create_table :mailwrapper_senders do |t|
      t.column :project_id,     :integer, :null => false
      t.column :sender,         :string,  :null => false
    end
  end

  def self.down
    drop_table :mailwrapper_senders
  end
end

