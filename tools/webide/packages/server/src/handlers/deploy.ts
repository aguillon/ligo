import joi from '@hapi/joi';
import { TezosToolkit } from '@taquito/taquito';
import { importKey } from '@taquito/signer';
import { Request, Response } from 'express';

import { CompilerError, LigoCompiler } from '../ligo-compiler';
import { logger } from '../logger';
import { fetchRandomPrivateKey } from '../services/key';

interface DeployBody {
  syntax: string;
  code: string;
  entrypoint: string;
  storage: string;
  network: string;
  protocol: string;
}

const Tezos = (network: string) => {
  switch (network) {
    case "mainnet":
      return new TezosToolkit(`https://mainnet.api.tez.ie`);
    case "ghostnet":   
      return new TezosToolkit(`https://ghostnet.ecadinfra.com`);
    case "kathmandunet":   
      return new TezosToolkit(`https://kathmandunet.ecadinfra.com`);
    default : 
      return new TezosToolkit("empty");
  }
}

const validateRequest = (body: any): { value: DeployBody; error?: any } => {
  return joi
    .object({
      syntax: joi.string().required(),
      code: joi.string().required(),
      entrypoint: joi.string().required(),
      storage: joi.string().required(),
      protocol: joi.string().required(),
      network: joi.string().required(),
    })
    .validate(body);
};

export async function deployHandler(req: Request, res: Response) {
  const { error, value: body } = validateRequest(req.body);
  if (error) {
    res.status(400).json({ error: error.message });
  } else {
    try {
      const michelsonCode = await new LigoCompiler().compileContract(
        body.syntax,
        body.code,
        body.entrypoint,
        'json',
        body.protocol
      );

      const michelsonStorage = await new LigoCompiler().compileStorage(
        body.syntax,
        body.code,
        body.entrypoint,
        'json',
        body.storage,
        body.protocol
      );

      const TezosNetwork = Tezos(body.network);

      await importKey(TezosNetwork, await fetchRandomPrivateKey(body.network));

      const op = await TezosNetwork.contract.originate({
        code: JSON.parse(michelsonCode),
        init: JSON.parse(michelsonStorage),
      });

      const contract = await op.contract();

      res.send({ address: contract.address, storage: michelsonStorage });
    } catch (ex) {
      if (ex instanceof CompilerError) {
        res.status(400).json({ error: ex.message });
      } else {
        logger.error((ex as Error).message);
        res.status(500).json({ error: (ex as Error).message });
      }
    }
  }
}
