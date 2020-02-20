require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?

get '/' do
  '/'
end

post "/" do
  json(
    {
      response_type: "in_channel",
      attachments: [
        {
          text: "",
          image_url: "https://minioext.veverka.net/meatsweats/2020-02-19/images/segment-151848.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=meatsweats%2F20200220%2F%2Fs3%2Faws4_request&X-Amz-Date=20200220T020109Z&X-Amz-Expires=432000&X-Amz-SignedHeaders=host&X-Amz-Signature=7fe631f3bac2bd38b33312e3d58ee1d250add09aff9d1ce7413ab563d3662970"
        }
      ]
    })

end
