ActiveAdmin.register User do
  menu parent: 'Users'
  permit_params :email, :full_name, :credits
  # actions :all, :except => [:destroy]
  config.clear_action_items!
  
  index do
    column :id
    column :email
    column :full_name
    column :locale
    column "Containers counts" do |u|
      count = u.containers.count.to_s
      url = "/admin/containers?utf8=✓&q[user_id_eq]=#{u.id}&commit=Filter&order=id_desc"
      a count, href: url
    end
    bool_column :confirmation
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

    div do
      link_to 'Prev user', edit_admin_user_path(id: resource.id - 1)
    end
    div do
      link_to 'Next user', edit_admin_user_path(id: resource.id + 1)
    end
    # actions do
    #   submit, as: :button, label: 'Optional custom label'
    #   cancel, as: :link # I think could converted to button as submit
    #   link_to 'Preview', admin_user_path(resource)
    # end
  end
  
  csv force_quotes: false, col_sep: ',', column_names: true do
    column :email
    column :full_name
    column :locale
    column("Has servers") { |u| !Container.where(user_id: u.id).blank? }
  end
end
