require "spec_helper"

describe Lita::Handlers::Bukkit, lita_handler: true do
  it { routes_command("bukkit me").to(:fetch) }

  describe "#fetch" do
    let(:response) { double("Faraday::Response") }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(response)
    end

    it "replies with an image URL on success" do
      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return(<<-HTML.chomp
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
 <head>
  <title>Index of /</title>
 </head>
 <body>
<h1>Index of /</h1>
<table>
  <tr>
    <th><img src="/icons/blank.gif" alt="[ICO]"></th>
    <th><a href="?C=N;O=A">Name</a></th>
    <th><a href="?C=M;O=A">Last modified</a></th>
    <th><a href="?C=S;O=A">Size</a></th>
    <th><a href="?C=D;O=A">Description</a></th>
  </tr>
  <tr>
    <th colspan="5"><hr></th>
  </tr>
  <tr>
    <td valign="top"><img src="/icons/image2.gif" alt="[IMG]"></td>
    <td><a href="googleglass.gif">googleglass.gif</a></td>
    <td align="right">19-Nov-2013 12:41  </td>
    <td align="right">860K</td>
  </tr>
</table>
</body>
</html>
HTML
        )

      send_command("bukkit me")

      expect(replies.last).to eq("http://bukk.it/googleglass.gif")
    end

    it "logs a warning on failure" do
      allow(response).to receive(:status).and_return(500)

      expect(Lita.logger).to receive(:warn).with(/Bukkit could not be reached./)

      send_command("bukkit me")

      expect(replies).to be_empty
    end
  end
end
