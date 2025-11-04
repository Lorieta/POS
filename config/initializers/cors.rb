# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_URL", "http://localhost:5173"), 
            "http://localhost:3000",
            "https://vue-frontend-njo94cc3g-lorietas-projects.vercel.app",
            /https:\/\/vue-frontend-.*\.vercel\.app$/
    
    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
