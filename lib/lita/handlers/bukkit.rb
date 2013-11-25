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
        links = parse_rows(Nokogiri::HTML(resp.body)).compact
        "#{URL}/#{parse_hrefs(links).sample}"
      end

      def parse_rows(page)
        extract_rows(page).map { |row| row.css("a").first }
      end

      def extract_rows(page)
        page.css("tr").slice(2..-1)
      end

      def parse_hrefs(links)
        links.map { |link| link.attributes["href"] }.compact.map(&:value)
      end
    end

    Lita.register_handler(Bukkit)
  end
end
