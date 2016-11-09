ActiveAdmin.register Payment do
  index do
    column :id
    column :type
    column :status
    column :amount
    column :created_at
    actions
  end
end