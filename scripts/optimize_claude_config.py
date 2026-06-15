#!/usr/bin/env python3
"""
PuluSmartFlow — Claude CLI Config Optimizer
Merges token-saving and MCP server settings into ~/.claude.json safely.
"""

import os
import json
import shutil

CLAUDE_CONFIG_PATH = os.path.expanduser("~/.claude.json")
CLAUDE_CONFIG_BAK = os.path.expanduser("~/.claude.json.bak")

def main():
    print("⚙️  Starting Claude Code Config Optimization...")
    
    # 1. Get path to templates/claude.json
    script_dir = os.path.dirname(os.path.abspath(__file__))
    template_path = os.path.join(script_dir, "..", "templates", "claude.json")
    
    if not os.path.exists(template_path):
        print(f"❌ Template file not found at {template_path}")
        return
        
    with open(template_path, "r", encoding="utf-8") as f:
        template_data = json.load(f)
        
    # 2. Read existing ~/.claude.json
    existing_data = {}
    if os.path.exists(CLAUDE_CONFIG_PATH):
        print(f"   Found existing config at {CLAUDE_CONFIG_PATH}, creating backup...")
        shutil.copy2(CLAUDE_CONFIG_PATH, CLAUDE_CONFIG_BAK)
        print(f"   💾 Backup created at {CLAUDE_CONFIG_BAK}")
        
        try:
            with open(CLAUDE_CONFIG_PATH, "r", encoding="utf-8") as f:
                existing_data = json.load(f)
        except Exception as e:
            print(f"   ⚠️  Could not parse existing ~/.claude.json ({e}). Overwriting...")
            
    # 3. Merge token optimization keys
    keys_to_merge = [
        "tengu_swann_brevity",
        "tengu_amber_wren",
        "tengu_auto_mode_config",
        "tengu_sm_config",
        "tengu_prompt_cache_1h_config",
        "tengu_pewter_kestrel"
    ]
    
    for key in keys_to_merge:
        if key in template_data:
            existing_data[key] = template_data[key]
            
    # 4. Merge mcpServers
    if "mcpServers" not in existing_data:
        existing_data["mcpServers"] = {}
        
    template_mcp = template_data.get("mcpServers", {})
    for server_name, server_config in template_mcp.items():
        # Update command path if headroom or agentmemory is found in standard bin paths
        mcp_cmd = server_config["command"]
        
        # Check standard installation locations for macOS
        user_local_bin = os.path.expanduser("~/.local/bin")
        full_mcp_cmd_path = os.path.join(user_local_bin, mcp_cmd)
        
        if os.path.exists(full_mcp_cmd_path):
            server_config["command"] = full_mcp_cmd_path
        elif mcp_cmd == "agentmemory-mcp-wrapper":
            # agentmemory might be installed as wrapper
            wrapper_path = os.path.join(user_local_bin, "agentmemory-mcp-wrapper")
            if os.path.exists(wrapper_path):
                server_config["command"] = wrapper_path
                
        # Merge if not already present, or override
        existing_data["mcpServers"][server_name] = server_config
        
    # 5. Write back to ~/.claude.json
    try:
        with open(CLAUDE_CONFIG_PATH, "w", encoding="utf-8") as f:
            json.dump(existing_data, f, indent=2)
        print("✅ Config optimized and saved successfully!")
    except Exception as e:
        print(f"❌ Failed to save optimized config: {e}")

if __name__ == "__main__":
    main()
