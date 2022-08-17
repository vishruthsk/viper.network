package viper_test

import (
	"testing"

	"github.com/stretchr/testify/require"
	keepertest "viper/testutil/keeper"
	"viper/testutil/nullify"
	"viper/x/viper"
	"viper/x/viper/types"
)

func TestGenesis(t *testing.T) {
	genesisState := types.GenesisState{
		Params: types.DefaultParams(),

		// this line is used by starport scaffolding # genesis/test/state
	}

	k, ctx := keepertest.ViperKeeper(t)
	viper.InitGenesis(ctx, *k, genesisState)
	got := viper.ExportGenesis(ctx, *k)
	require.NotNil(t, got)

	nullify.Fill(&genesisState)
	nullify.Fill(got)

	// this line is used by starport scaffolding # genesis/test/assert
}
