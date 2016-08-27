ActiveAdmin.register User do
  menu parent: 'Users'
  permit_params :email, :full_name, :credits
  actions :all, :except => [:destroy]
  config.clear_action_items!
  
  index do
    column :id
    column :email
    column :full_name
    column :locale
    column "Has servers" do |u|
      !Container.where(user_id: u.id).blank?
    end
    column :credits
    column :created_at
    actions
  end
  
  filter :email
  filter :full_name
  filter :locale
  filter :created_at
  
  form do |f|
    inputs 'Details' do
      input :email
      input :full_name
      input :credits
    end
    actions
  end
  
  csv force_quotes: false, col_sep: ',', column_names: true do
    column :email
    column :full_name
    column :locale
    column("Has servers") { |u| !Container.where(user_id: u.id).blank? }
  end
end
