import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "mac-app"))
import marketpulse


class LocalAgentTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.old_home = marketpulse.AGENT_HOME
        self.old_path = marketpulse.AGENT_STORE_PATH
        marketpulse.AGENT_HOME = Path(self.tmp.name)
        marketpulse.AGENT_STORE_PATH = marketpulse.AGENT_HOME / "agent_store.json"

    def tearDown(self):
        marketpulse.AGENT_HOME = self.old_home
        marketpulse.AGENT_STORE_PATH = self.old_path
        self.tmp.cleanup()

    def test_long_position_triggers_one_adverse_alert(self):
        store = marketpulse._default_agent_store()
        position = marketpulse.normalise_position({
            "asset_key": "gold",
            "direction": "long",
            "tracking_price": 100,
            "adverse_alert_pct": 0.5,
            "label": "Oro long",
        })
        store["positions"] = [position]
        store["settings"]["market_move_pct"] = 5
        marketpulse.save_agent_store(store)
        data = {
            "assets": {"gold": {"price": 99.0, "change_pct": 0.0}},
            "news": [],
        }
        with patch("marketpulse.send_mac_notification", return_value=True) as notify:
            marketpulse.scan_agent_once(data)
            marketpulse.scan_agent_once(data)
        notify.assert_called_once()
        saved = marketpulse.load_agent_store()
        self.assertTrue(saved["state"]["position_alerts"][position["id"]]["adverse"])

    def test_short_position_uses_inverse_direction(self):
        store = marketpulse._default_agent_store()
        position = marketpulse.normalise_position({
            "asset_key": "usdjpy",
            "direction": "short",
            "tracking_price": 150,
            "adverse_alert_pct": 0.5,
        })
        store["positions"] = [position]
        store["settings"]["market_move_pct"] = 5
        marketpulse.save_agent_store(store)
        data = {
            "assets": {"usdjpy": {"price": 151.0, "change_pct": 0.0}},
            "news": [],
        }
        with patch("marketpulse.send_mac_notification", return_value=True) as notify:
            marketpulse.scan_agent_once(data)
        notify.assert_called_once()
        self.assertIn("avversa", notify.call_args.args[1])

    def test_invalid_threshold_is_rejected(self):
        with self.assertRaises(ValueError):
            marketpulse.normalise_position({
                "asset_key": "gold",
                "direction": "long",
                "tracking_price": 100,
                "adverse_alert_pct": 50,
            })

    def test_position_is_local_json_store(self):
        store = marketpulse._default_agent_store()
        position = marketpulse.normalise_position({
            "asset_key": "wti",
            "direction": "long",
            "tracking_price": 70,
            "adverse_alert_pct": 1.0,
        })
        store["positions"] = [position]
        marketpulse.save_agent_store(store)
        self.assertTrue(marketpulse.AGENT_STORE_PATH.exists())
        self.assertEqual(marketpulse.load_agent_store()["positions"][0]["asset_key"], "wti")


if __name__ == "__main__":
    unittest.main()
