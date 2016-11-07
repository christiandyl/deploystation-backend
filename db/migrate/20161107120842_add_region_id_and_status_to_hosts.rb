class AddRegionIdAndStatusToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :status, :string
    add_reference :hosts, :region, index: true
  end
end
