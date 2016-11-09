ActiveAdmin.register Payment do
  index do
    column :id
    column :type
    column 'Type' { |p| p.type }
    column 'Status' { |p| p.status }
    column :created_at
    actions
  end
end