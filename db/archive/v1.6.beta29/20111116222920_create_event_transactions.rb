class CreateEventTransactions < ActiveRecord::Migration
  def self.up
    create_table :event_transactions do |t|
      t.references :event, :campaign
      t.integer :total_paid
      t.string :transaction_id, :cc_first_name, :cc_last_name, :cc_number, 
               :cc_expire_month, :cc_expire_year, :response_code, 
               :response_reason_code, :response_reason_text, 
               :avs_result_code, :transaction_id
      t.timestamps
    end
  end

  def self.down
    drop_table :event_transactions
  end
end
