ActiveAdmin.register Game do
  permit_params :name, :active_until, :is_paid

  actions :all, :except => [:destroy]

  index do
    column :id
    column :name
    column :sname
    column :status
    column :created_at
    column :updated_at
    actions
  end

end
