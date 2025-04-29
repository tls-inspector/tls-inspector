// TLS Inspector
// Copyright (C) Ian Spence and other TLS Inspector Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation

@MainActor
public struct FunStuff {
    public static func randomQuote() -> String {
        return [
            "Never send a boy to do a woman's job.",
            "Never fear, I is here.",
            "There is no right or wrong, just fun and boring.",
            "Kid, don't threaten me. There are worse things than death, and uh, I can do all of them.",
            "Boot Up or Shut Up!",
            "We have just gotten a wake-up call from the Nintendo Generation.",
            "His parents missed Woodstock, and he's been making up for it since.",
            "This is the end, my friend. Thank you for calling.",
        ].randomElement() ?? ""
    }

    public static func randomWebsite() -> String {
        return [
            "aliexpress.com",
            "amazon.com",
            "dns-inspector.com",
            "ebay.com",
            "ellingson-minerals.com",
            "facebook.com",
            "google.com",
            "imgur.com",
            "instagram.com",
            "linkedin.com",
            "netflix.com",
            "reddit.com",
            "tlsinspector.com",
            "tumblr.com",
            "twitch.tv",
            "wikipedia.org",
            "wordpress.com",
            "www.apple.com",
            "www.nsa.gov",
            "yahoo.com",
            "youtube.com",
        ].randomElement() ?? ""
    }
}
