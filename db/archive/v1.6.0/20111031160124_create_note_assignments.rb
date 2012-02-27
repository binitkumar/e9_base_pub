class CreateNoteAssignments < ActiveRecord::Migration
  def self.up
    create_table :note_assignments do |t|
      t.references :assigned, :polymorphic => true
      t.references :note
      t.timestamps
    end
  end

  def self.down
    drop_table :note_assignments
  end
end
