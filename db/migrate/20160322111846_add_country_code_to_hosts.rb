class AddCountryCodeToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :country_code, :string
  end
end
