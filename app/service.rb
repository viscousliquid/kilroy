require 'kilroy'
require 'markaby/sinatra'
require 'json'


Jabber::Bot::Instance = Jabber::Bot::Kilroy.new

get '/' do
  redirect '/view/home/'
end

get '/view/*' do
  view, *args = params[:splat][0].split('/')

  case view
    when 'home'
      mab :index
    when 'status'
      mab :status
    when 'configuration'
      mab :configuration
    when 'modules'
      mab :modules
    when 'logs'
      mab :logs
    else
      redirect '/view/home'
  end
end

post '/data/:view' do
  begin
    case params[:view]
      when 'status'
        case params[:type]
          when 'list'
            retval = {  :status => 'success',
                        :content => { :connected => Jabber::Bot::Instance.is_connected?,
                                      :rooms => Jabber::Bot::Instance.rooms
                      }
            }
          else
            retval = { :status => 'error', :message => "unknown modules flag: #{params[:type]}"}
        end

        retval.to_json
      when 'configuration'
        case params[:type]
          when 'list'
            retval = {  :status => 'success',
                        :content => Jabber::Bot::Instance.env.to_hash
            }
          when 'update'
            attrs = JSON.parse(params[:update])
            attrs.each do |k,v|
              Jabber::Bot::Instance.env[k] = v
            end

            retval = {  :status => 'success',
                        :content => Jabber::Bot::Instance.env.to_hash
            }
          else
            retval = { :status => 'error', :message => "unknown modules flag: #{params[:type]}"}
        end
        
        retval.to_json
      when 'modules'
        case params[:type]
          when 'list'
            retval = {  :status => 'success',
                        :content => Jabber::Bot::Models::Module.list
            }
          when 'content'
            mod_name = params[:module]

            retval = {  :status => 'success',
                        :content => Jabber::Bot::Models::Module.get(mod_name)
            }
          when 'update'
            attrs = JSON.parse(params[:update])
            mod = Jabber::Bot::Models::Module.find(attrs['id'])

            retval = {  :status => 'success',
                        :content => mod.revision(attrs)
            }
          when 'delete'
            attrs = JSON.parse(params[:update])
            mod = Jabber::Bot::Models::Module.find(attrs['id'])

            retval = {  :status => 'success',
                        :content => mod.delete(user)
            }
          else
            retval = { :status => 'error', :message => "unknown modules flag: #{params[:type]}"}
        end

        retval.to_json
      when 'logs'
        type = params[:type]

        case type
          when 'im'
            @params[:start] = 0 unless @params[:start]
            @params[:count] = 20 unless @params[:count]
            @params[:query] = '%' unless @params[:query]
            recorder = Jabber::Bot::Instance.recorder
            retval = {  :status => 'success',
                        :content => recorder.get_im(@params[:start],@params[:count],@params[:query])
            }
          when 'muc'
            @params[:room] = '%' unless @params[:room]
            @params[:start] = 0 unless @params[:start]
            @params[:count] = 20 unless @params[:count]
            @params[:query] = '%' unless @params[:query]
            recorder = Jabber::Bot::Instance.recorder
            retval = {  :status => 'success',
                        :content => recorder.get_muc(@params[:room],@params[:start],@params[:count],@params[:query])
            }
          else
            retval = { :status => 'error', :message => "unknown logs flag: #{params[:type]}"}
        end
        
        retval.to_json
      else
        {:status => 'error', :message => 'unknown data view'}.to_json
    end #end case
  rescue Exception => e
    { :status => "failed", :message => "#{e.to_s}\n#{e.backtrace}"}.to_json
  end
end

put '/methods/:method' do
  begin
    case params[:method]
      when 'start'
        unless Jabber::Bot::Instance.is_connected?
            Jabber::Bot::Instance.connect
            status = Jabber::Bot::Instance.is_connected?
        end
      when 'stop'
        Jabber::Bot::Instance.disconnect
        status = Jabber::Bot::Instance.is_connected?
      else
    end #end case
  rescue Exception => e
    status = "failed"
    message = e.to_s
  end

  { :status => status, :message => message}.to_json
end

