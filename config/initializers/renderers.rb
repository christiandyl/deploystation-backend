ActionController::Renderers.add :text do |object, options|
  self.content_type ||= Mime::FOO
  object.respond_to?(:text) ? object.to_file : object
end