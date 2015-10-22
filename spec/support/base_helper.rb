module BaseHelper

  DEFAULT_HEADERS    = { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

  def send type, path, **opts
    raise ArgumentError, "Path option must be in hash" unless path

    token = JWT.encode({}, Settings.token_encoding.decryption_key, Settings.token_encoding.algorithm)

    method  = method(type || 'get')
    params  = opts[:params] || {}
    headers = opts[:headers] || get_headers(token || nil)

    method.call path, params, headers
  end

  def current_params
    p = {}
    current_url.match(/\?(.*)$/)[1].split('#')[0].split("&").each do |e|
      spl = e.split('=')
      p[spl[0]] = spl[1] || nil
    end
    return p.with_indifferent_access
  end

  def get_headers(token = nil)
    headers = BaseHelper::DEFAULT_HEADERS
    headers['X-Auth-Token'] = token unless token.nil?
    headers
  end

end