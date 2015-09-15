package modelhelper

import (
	"fmt"
	"koding/db/models"
	"koding/kites/kloud/stackstate"
	"time"

	"labix.org/v2/mgo"
	"labix.org/v2/mgo/bson"
)

const ComputeStackColl = "jComputeStacks"

func GetComputeStack(id string) (*models.ComputeStack, error) {
	if !bson.IsObjectIdHex(id) {
		return nil, fmt.Errorf("Not valid ObjectIdHex: '%s'", id)
	}

	computeStack := new(models.ComputeStack)
	query := func(c *mgo.Collection) error {
		return c.FindId(bson.ObjectIdHex(id)).One(&computeStack)
	}

	if err := Mongo.Run(ComputeStackColl, query); err != nil {
		return nil, err
	}

	return computeStack, nil
}

func DeleteComputeStack(id string) error {
	query := func(c *mgo.Collection) error {
		return c.RemoveId(bson.ObjectIdHex(id))
	}

	return Mongo.Run(ComputeStackColl, query)
}

func SetStackState(id, reason string, state stackstate.State) error {
	query := func(c *mgo.Collection) error {
		return c.UpdateId(id, bson.M{
			"$set": bson.M{
				"status.state":      state.String(),
				"status.modifiedAt": time.Now().UTC(),
				"status.reason":     reason,
			},
		})
	}

	return Mongo.Run(ComputeStackColl, query)
}
