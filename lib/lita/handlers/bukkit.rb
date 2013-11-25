require "lita"
require "nokogiri"

module Lita
  module Handlers
    class Bukkit < Handler
      URL = "http://bukk.it"

      route %r{bukkit me}, :fetch, command: true, help: {
        "bukkit me" => "Fetches a random image from bukkit."
      }

      def fetch(response)
        http_resp = http.get(URL)

        if http_resp.status == 200
          response.reply extract_image_url_from(http_resp)
        else
          Lita.logger.warn("Bukkit could not be reached.")
        end
      end

      private

      def extract_image_url_from(resp)
        page  = Nokogiri::HTML(resp.body)
        rows  = page.css("tr").slice(2..-1)
        links = rows.map { |row| row.css("a").first }.compact
        hrefs = links.map { |link| link.attributes["href"] }.compact.map(&:value)
        "#{URL}/#{hrefs.sample}"
      end
    end

    Lita.register_handler(Bukkit)
  end
end
